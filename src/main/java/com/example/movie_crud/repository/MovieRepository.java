package com.example.movie_crud.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.movie_crud.dto.MovieDto;

public interface MovieRepository extends JpaRepository<MovieDto, Long>{
	

}
